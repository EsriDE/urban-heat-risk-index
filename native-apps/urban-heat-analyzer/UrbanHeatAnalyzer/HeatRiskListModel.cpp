// "Urban Heat Analyzer"
// Copyright (C) 2024 Esri Deutschland GmbH
// Jan Tschada (j.tschada@esri.de)
//
// SPDX-License-Identifier: GPL-3.0-only
//
// Additional permission under GNU GPL version 3 section 7
//
// If you modify this Program, or any covered work, by linking or combining
// it with ArcGIS Maps SDK for Qt (or a modified version of that library),
// containing parts covered by the terms of ArcGIS Maps SDK for Qt,
// the licensors of this Program grant you additional permission to convey the resulting work.
// See <https://developers.arcgis.com/qt/> for further information.

#include "HeatRiskListModel.h"

#include "AttributeListModel.h"
#include "Feature.h"
#include "Geometry.h"
#include "GeometryEngine.h"

using namespace Esri::ArcGISRuntime;


HeatRiskAnalysisGroup::HeatRiskAnalysisGroup(double heatRiskIndex)
    : m_heatRiskIndex(heatRiskIndex)
{

}

bool HeatRiskAnalysisGroup::operator==(const HeatRiskAnalysisGroup &other) const
{
    if (m_heatRiskIndex != other.m_heatRiskIndex)
    {
        return false;
    }

    if (m_heatRiskFeatures.count() != other.m_heatRiskFeatures.count())
    {
        return false;
    }

    // Compare features just using the geometry
    for (auto index=0; index < m_heatRiskFeatures.count(); index++)
    {
        auto feature = m_heatRiskFeatures[index];
        auto otherFeature = other.m_heatRiskFeatures[index];
        if (!feature->geometry().equalsWithTolerance(otherFeature->geometry(), 0.001))
        {
            return false;
        }
    }

    return true;
}

QString HeatRiskAnalysisGroup::name() const
{
    if (m_heatRiskFeatures.empty())
    {
        return "Unknown";
    }

    auto heatRiskFeatureAttributes = m_heatRiskFeatures.first()->attributes();
    return heatRiskFeatureAttributes->attributeValue("GRID_ID").toString();
}

double HeatRiskAnalysisGroup::heatRiskIndex() const
{
    return m_heatRiskIndex;
}

void HeatRiskAnalysisGroup::addFeature(Feature *heatRiskFeature)
{
    m_heatRiskFeatures.append(heatRiskFeature);
}

Geometry HeatRiskAnalysisGroup::areaOfInterest()
{
    QList<Geometry> geometries;
    for (auto heatRiskFeature : m_heatRiskFeatures)
    {
        geometries.append(heatRiskFeature->geometry());
    }

    return GeometryEngine::unionOf(geometries);
}


HeatRiskListModel::HeatRiskListModel(QObject *parent)
    : QAbstractListModel{parent}
{

}

void HeatRiskListModel::loadAnalysisGroups(const QList<HeatRiskAnalysisGroup> &analysisGroups)
{
    beginResetModel();
    m_analysisGroups = analysisGroups;
    endResetModel();

    // Emit that the full data has changed
    emit dataChanged(index(0,0), index(rowCount() - 1));
}

void HeatRiskListModel::select(int index)
{
    if (m_selectedIndex != index)
    {
        m_selectedIndex = index;
        emit selectedHeatRiskItemChanged();
    }
}

HeatRiskAnalysisGroup* HeatRiskListModel::selectedGroup() const
{
    if (m_selectedIndex < 0 || m_analysisGroups.count() <= m_selectedIndex)
    {
        return nullptr;
    }

    return &const_cast<HeatRiskListModel*>(this)->m_analysisGroups[m_selectedIndex];
}

void HeatRiskListModel::setSelectedGroup(HeatRiskAnalysisGroup *group)
{
    auto index_of = m_analysisGroups.indexOf(*group);
    if (m_selectedIndex != index_of)
    {
        m_selectedIndex = index_of;
        emit selectedHeatRiskItemChanged();
    }
}

int HeatRiskListModel::rowCount(const QModelIndex &parent) const {
    Q_UNUSED(parent);
    return m_analysisGroups.count();
}

QVariant HeatRiskListModel::data(const QModelIndex &index, int role) const {
    if (index.row() < 0 || index.row() >= m_analysisGroups.count())
        return QVariant();

    const HeatRiskAnalysisGroup &analysisGroup = m_analysisGroups[index.row()];
    if (role == NameRole)
        return analysisGroup.name();
    else if (role == RiskRole)
        return analysisGroup.heatRiskIndex();
    return QVariant();
}

QHash<int, QByteArray> HeatRiskListModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[NameRole] = "name";
    roles[RiskRole] = "risk";
    return roles;
}
