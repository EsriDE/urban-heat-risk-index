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

#ifndef HEATRISKLISTMODEL_H
#define HEATRISKLISTMODEL_H

#include <QAbstractListModel>
#include <QObject>

namespace Esri::ArcGISRuntime {
class Feature;
class Geometry;
} // namespace Esri::ArcGISRuntime


class HeatRiskAnalysisGroup
{
public:
    HeatRiskAnalysisGroup(double heatRiskIndex);

    QString name() const;
    double heatRiskIndex() const;

    void addFeature(Esri::ArcGISRuntime::Feature *heatRiskFeature);
    Esri::ArcGISRuntime::Geometry areaOfInterest();

    bool operator==(const HeatRiskAnalysisGroup &other) const;

private:
    double m_heatRiskIndex;
    QList<Esri::ArcGISRuntime::Feature*> m_heatRiskFeatures;
};


class HeatRiskListModel : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(HeatRiskAnalysisGroup *selectedGroup
                READ selectedGroup WRITE setSelectedGroup
                NOTIFY selectedHeatRiskItemChanged)

public:
    enum HeatRiskRoles {
        NameRole = Qt::UserRole + 1,
        RiskRole
    };

    explicit HeatRiskListModel(QObject *parent = nullptr);

    void loadAnalysisGroups(const QList<HeatRiskAnalysisGroup> &analysisGroups);
    Q_INVOKABLE void select(int index);

    int rowCount(const QModelIndex &parent = QModelIndex()) const;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;

    HeatRiskAnalysisGroup *selectedGroup() const;

signals:
    void selectedHeatRiskItemChanged();

protected:
    QHash<int, QByteArray> roleNames() const;

private:
    void setSelectedGroup(HeatRiskAnalysisGroup *group);

    QList<HeatRiskAnalysisGroup> m_analysisGroups;
    int m_selectedIndex = -1;
};

#endif // HEATRISKLISTMODEL_H
